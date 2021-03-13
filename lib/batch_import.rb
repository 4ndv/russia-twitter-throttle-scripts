class BatchImport
  def self.import(table, chunk)
    items = chunk.map do |item|
      ActiveRecord::Base.send(:replace_bind_variables, "(#{item.values.size.times.collect {'?'}.join(',')})", item.values)
    end

    ActiveRecord::Base.connection.execute(<<-SQL)
      INSERT INTO
        #{table}
      (#{chunk.first.keys.join(',')})
      VALUES #{items.join(",")}
    SQL
  end
end
