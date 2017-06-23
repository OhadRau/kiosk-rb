class Code < ActiveRecord::Base
  def self.create(num = 1)
    num.times do
      # FIXME: Generated number *may* not be unique
      Code.create(SecureRandom.random_number(10_000))
    end
  end

  def self.validate(code)
    row = Code.where(code: code)
    row.first.delete if row.present?
    row.present?
  end
end
