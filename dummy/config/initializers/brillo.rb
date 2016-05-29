Brillo.configure do |config|
  config.add_tactic :oldest, -> (klass) { klass.order(created_at: :desc).limit(1000) }

  config.add_obfuscation(:remove_ls, -> (field) {
    field.gsub(/l/, "X")
  })

  config.add_obfuscation(:phone_with_id, -> (field, instance) {
    (555_000_0000 + instance.id).to_s
  })
end
