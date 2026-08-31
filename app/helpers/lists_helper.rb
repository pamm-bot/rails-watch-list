module ListsHelper
  # Cycles through the app's accent palette so each list card gets a
  # distinct top border instead of every card looking identical.
  ACCENT_COLORS = %w[#f77f00 #e0218a #7209b7 #118ab2 #06d6a0].freeze

  def list_accent_color(index)
    ACCENT_COLORS[index % ACCENT_COLORS.length]
  end
end
