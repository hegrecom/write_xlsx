# -*- coding: utf-8 -*-
require 'write_xlsx/package/xml_writer_simple'
require 'write_xlsx/utility'

module Writexlsx
  module Package
    class ContentTypes

      include Writexlsx::Utility

      App_package  = 'application/vnd.openxmlformats-package.'
      App_document = 'application/vnd.openxmlformats-officedocument.'

      def initialize
        @writer = Package::XMLWriterSimple.new
        @defaults  = [
          [ 'rels', "#{App_package}relationships+xml" ],
          [ 'xml', 'application/xml' ]
        ]
        @overrides = [
          [ '/docProps/app.xml',    "#{App_document}extended-properties+xml" ],
          [ '/docProps/core.xml',   "#{App_package}core-properties+xml" ],
          [ '/xl/styles.xml',       "#{App_document}spreadsheetml.styles+xml" ],
          [ '/xl/theme/theme1.xml', "#{App_document}theme+xml" ],
          [ '/xl/workbook.xml',     "#{App_document}spreadsheetml.sheet.main+xml" ]
        ]
      end

      def set_xml_writer(filename)
        @writer.set_xml_writer(filename)
      end

      def assemble_xml_file
        write_xml_declaration
        write_types do
          write_defaults
          write_overrides
        end
        @writer.crlf
        @writer.close
      end
      #
      # Add elements to the ContentTypes defaults.
      #
      def add_default(part_name, content_type)
        @defaults.push([part_name, content_type])
      end

      #
      # Add elements to the ContentTypes overrides.
      #
      def add_override(part_name, content_type)
        @overrides.push([part_name, content_type])
      end

      #
      # Add the name of a worksheet to the ContentTypes overrides.
      #
      def add_worksheet_name(name)
        worksheet_name = "/xl/worksheets/#{name}.xml"

        add_override(worksheet_name, "#{App_document}spreadsheetml.worksheet+xml")
      end

      #
      # Add the name of a chartsheet to the ContentTypes overrides.
      #
      def add_chartsheet_name(name)
        chartsheet_name = "/xl/chartsheets/#{name}.xml"

        add_override(chartsheet_name, "#{App_document}spreadsheetml.chartsheet+xml")
      end

      #
      # Add the name of a chart to the ContentTypes overrides.
      #
      def add_chart_name(name)
        chart_name = "/xl/charts/#{name}.xml"

        add_override(chart_name, "#{App_document}drawingml.chart+xml")
      end

      #
      # Add the name of a drawing to the ContentTypes overrides.
      #
      def add_drawing_name(name)
        drawing_name = "/xl/drawings/#{name}.xml"

        add_override( drawing_name, "#{App_document}drawing+xml")
      end

      #
      # Add the name of a VML drawing to the ContentTypes defaults.
      #
      def add_vml_name
        add_default('vml', "#{App_document}vmlDrawing")
      end

      #
      # Add the name of a comment to the ContentTypes overrides.
      #
      def add_comment_name(name)
        comment_name = "/xl/#{name}.xml"

        add_override( comment_name, "#{App_document}spreadsheetml.comments+xml")
      end

      #
      # Add the sharedStrings link to the ContentTypes overrides.
      #
      def add_shared_strings
        add_override('/xl/sharedStrings.xml', "#{App_document}spreadsheetml.sharedStrings+xml")
      end

      #
      # Add the calcChain link to the ContentTypes overrides.
      #
      def add_calc_chain
        add_override('/xl/calcChain.xml', "#{App_document}spreadsheetml.calcChain+xml")
      end

      #
      # Add the image default types.
      #
      def add_image_types(types)
        types.each_key { |type| add_default(type, "image/#{type}") }
      end

      #
      # Add the name of a table to the ContentTypes overrides.
      #
      def add_table_name(table_name)
        add_override(
                     "/xl/tables/#{table_name}.xml",
                     "#{App_document}spreadsheetml.table+xml"
                     )
      end

      #
      # Add a vbaProject to the ContentTypes defaults.
      #
      def add_vba_project
        change_the_workbook_xml_content_type_from_xlsx_to_xlsm
        add_default('bin', 'application/vnd.ms-office.vbaProject')
      end

      private

      def write_xml_declaration
        @writer.xml_decl
      end

      def change_the_workbook_xml_content_type_from_xlsx_to_xlsm
        @overrides.collect! do |arr|
          if arr[0] == '/xl/workbook.xml'
            arr[1] = 'application/vnd.ms-excel.sheet.macroEnabled.main+xml'
          end
          arr
        end
      end

      #
      # Write out all of the <Default> types.
      #
      def write_defaults
        @defaults.each do |a|
          @writer.empty_tag('Default', ['Extension', a[0], 'ContentType', a[1]])
        end
      end

      #
      # Write out all of the <Override> types.
      #
      def write_overrides
        @overrides.each do |a|
          @writer.empty_tag('Override', ['PartName', a[0], 'ContentType', a[1]])
        end
      end

      #
      # Write the <Types> element.
      #
      def write_types
        xmlns = 'http://schemas.openxmlformats.org/package/2006/content-types'
        attributes = ['xmlns', xmlns]

        @writer.tag_elements('Types', attributes) { yield }
      end

      #
      # Write the <Default> element.
      #
      def write_default(extension, content_type)
        attributes = [
          'Extension',   extension,
          'ContentType', content_type
        ]

        @writer.empty_tag('Default', attributes)
      end

      #
      # Write the <Override> element.
      #
      def write_override(part_name, content_type)
        attributes = [
          'PartName',    part_name,
          'ContentType', content_type
        ]

        @writer.empty_tag('Override', attributes)
      end
    end
  end
end
