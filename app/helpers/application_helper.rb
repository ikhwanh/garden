module ApplicationHelper
  def currency_rp(amount)
    number_to_currency(amount, unit: "Rp", separator: ",", delimiter: ".", precision: 0, format: "%u %n")
  end

  def compatibility_badge(result)
    case result.level
    when :compatible
      tag.span("Compatible",
        class: "inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-green-100 text-green-700")
    when :marginal
      tag.span("Marginal",
        class: "inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-yellow-100 text-yellow-700")
    when :incompatible
      tag.span("Not recommended",
        class: "inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-red-100 text-red-700")
    when :incomplete_profile
      tag.span("Set farm profile",
        title: "Go to Settings to add your altitude, temperature and humidity",
        class: "inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-500")
    end
  end
end
