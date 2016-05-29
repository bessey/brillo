Brillo.configure do |config|
  ## Add extra tactics for selecting records as you need them
  # config.add_tactic :oldest, -> (klass) { klass.order(created_at: :desc).limit(1000) }

  ## Custom obfuscations can also be added
  # config.add_obfuscation :remove_ls, -> (field) {
  #   field.gsub(/l/, "X")
  # }

  ## If you need the context of the entire record being obfuscated, it is available in the second argument
  # config.add_obfuscation :phone_with_id, -> (field, instance) {
  #   (555_000_0000 + instance.id).to_s
  # }
end
