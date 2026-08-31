module ListsHelper
  def list_accent_color(list, index)
    list.color.presence || List::ACCENT_COLORS[index % List::ACCENT_COLORS.length]
  end
end
