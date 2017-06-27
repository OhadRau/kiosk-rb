class Code < ActiveRecord::Base
  def self.initN(num = 1)
    unless count > 10_000
      num.times do
        code = SecureRandom.random_number(10_000)
        while Code.exists?(code: code) do
          code = SecureRandom.random_number(10_000)
        end
        puts "Generated user sign-up code: #{code}"
        Code.create(:code => code)
      end
    end
  end

  def self.validate(code)
    row = Code.where(code: code)
    row.first.delete if row.present?
    row.present?
  end
end
