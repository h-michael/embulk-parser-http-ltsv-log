require 'date'

module Embulk
  module Parser

    class HttpLtsvLog < ParserPlugin
      Plugin.register_parser("http-ltsv-log", self)

      def self.transaction(config, &control)
        # configuration code:


        parser_task = config.load_config(Java::LineDecoder::DecoderTask)

        task = {
          "decoder_task" => DataSource.from_java(parser_task.dump)
          "charset" => config.param("charset", :string, default: "UTF-8"),
          "skip_header_lines" => config.param("skip_header_lines", :boolean, default: true),
        }

        columns = config.param("columns").map.with_index do |c, i|
          if [:boolean, :long, :timestamp, :double, :string].include?(c[:type])
            if c[:type] == :timestamp
              return Column.new(i, DateTime.parse(c[:name]), c[:type]) if c[:format].nil?
              return Column.new(i, DateTime.parse(c[:name], c[:format]) , c[:type])
            else
              return Column.new(i, c[:name], c[:type]) if c[:type]
            end
          end
        end

        yield(task, columns)
      end

      def init
        # initialization code:
        @decoder_task = task.param("decoder_task", :hash).load_task(Java::LineDecoder::DecoderTask)
        
        @charset = task["charset"]
        @skip_header_lines = task["skip_header_lines"]
      end

      def run(file_input)
        decoder = Java::LineDecoder.new(file_input.instance_eval { @java_file_input }, @decoder_task)
        while file = file_input.next_file
          file.each do |buffer|
            # parsering code
            record = ["col1", 2, 3.0]
            page_builder.add(record)
          end
        end
        page_builder.finish
      end
    end

  end
end
