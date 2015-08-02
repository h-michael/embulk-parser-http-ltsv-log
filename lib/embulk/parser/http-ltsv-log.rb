require 'date'

module Embulk
  module Parser
    class HttpLtsvLog < ParserPlugin
      Plugin.register_parser('http-ltsv-log', self)

      def self.transaction(config, &_control)
        parser_task = config.load_config(Java::LineDecoder::DecoderTask)
        task = {
          'decoder_task' => DataSource.from_java(parser_task.dump),
          'schema' => config.param('schema', :array)
        }
        columns = task['schema'].each_with_index.map do |c, i|
          Column.new(i, c['name'], c['type'].to_sym)
        end
        yield(task, columns)
      end

      def init
        @decoder_task = task.param('decoder_task', :hash).load_task(Java::LineDecoder::DecoderTask)
      end

      def run(file_input)
        decoder = Java::LineDecoder.new(file_input.instance_eval { @java_file_input }, @decoder_task)
        schema = @task['schema']

        while decoder.nextFile
          while line = decoder.poll
            begin
              hash = Hash[line.split("\t").map { |f| f.split(':', 2) }]
              @page_builder.add(make_record(schema, hash))
            rescue
              # TODO: logging
            end
          end
        end
        page_builder.finish
      end

      private

      def make_record(schema, e)
        schema.map do |c|
          val = e[c['name']]
          v = val.nil? ? '' : val
          case c['type']
          when 'string'
            v
          when 'long'
            v.to_i
          when 'double'
            v.to_f
          when 'boolean'
            %w(yes true 1).include?(v.downcase)
          when 'timestamp'
            if c['surrounded'] == true
              v.empty? ? nil : Time.strptime(v.gsub(/(^.|.$)/, ''), c['format'])
            else
              v.empty? ? nil : Time.strptime(v, c['format'])
            end
          else
            fail "Unsupported type #{c['type']}"
          end
        end
      end
    end
  end
end
