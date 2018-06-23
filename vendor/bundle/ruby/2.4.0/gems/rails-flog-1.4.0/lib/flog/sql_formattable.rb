require "active_record/log_subscriber"
require "flog/payload_value_shuntable"

module Flog::SqlFormattable
  include Flog::PayloadValueShuntable

  def sql(event)
    return super(event) unless formattable?(event)

    formatted = format_sql(event.payload[:sql])

    shunt_payload_value(event.payload, :sql, "\n\t#{formatted}") do
      super(event)
    end
  end

  private
  def format_sql(sql)
    return sql if sql.blank?

    require "anbt-sql-formatter/formatter"
    rule = AnbtSql::Rule.new
    rule.keyword = AnbtSql::Rule::KEYWORD_UPPER_CASE
    %w(count sum).each do |function_name|
      rule.function_names << function_name
    end
    rule.indent_string = "\t"
    AnbtSql::Formatter.new(rule).format(sql.squeeze(" "))
  end

  def formattable?(event)
    return false unless Flog::Status.sql_formattable?

    return false if ignore_by_cached_query?(event)

    duration_over?(event)
  end

  def ignore_by_cached_query?(event)
    (event.payload[:name] == "CACHE" || event.payload[:cached]) && Flog.config.ignore_cached_query?
  end

  def duration_over?(event)
    event.duration >= Flog.config.query_duration_threshold.to_f
  end
end

class ActiveRecord::LogSubscriber
  prepend Flog::SqlFormattable
end
