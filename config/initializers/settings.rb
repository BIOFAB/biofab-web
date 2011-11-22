# Usage: Settings['the_key']
Settings = YAML::load_file(File.join(Rails.root, "config", "settings.yml"))
