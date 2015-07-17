require 'date'

module Embulk
  module Parser

    class HttpLtsvLog < ParserPlugin
      Plugin.register_parser("http-ltsv-log", self)

      def self.transaction(config, &control)

        task = {
          # "skip_header_lines" => config.param("skip_header_lines", :boolean, default: true)
        }

        columns = config.param("columns", :array).map.with_index do |c, i|
          if ['boolean', 'long', 'timestamp', 'double', 'string'].include?(c['type'])
            if c['type'] == 'timestamp'
              col = Column.new(i, DateTime.parse(c['name']), c['type'].to_sym) if c['format'].nil?
              col =  Column.new(i, DateTime.parse(c['name'], c['format']) , c['type'].to_sym)
            else
              col = Column.new(i, c['name'], c['type'].to_sym)
            end
          else
            raise 'Wrong column type'
          end
          col
        end

        yield(task, columns)
      end

      def init
        # @skip_header_lines = task["skip_header_lines"]
      end

      def run(file_input)
        decoder_task = @task.load_config(Java::LineDecoder::DecoderTask)
        decoder = Java::LineDecoder.new(file_input.instance_eval { @java_file_input }, decoder_task)
        while decoder.nextFile
          while line = decoder.poll
            record = nil
            record = line.split("\t").map{ |column| column.gsub(/^[^:]*:/,'')}
            page_builder.add(record)
          end
        end
        page_builder.finish
      end
    end
  end
end
