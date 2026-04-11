module ApplicationHelper
  def currency_rp(amount)
    number_to_currency(amount, unit: "Rp", separator: ",", delimiter: ".", precision: 0, format: "%u %n")
  end
end
