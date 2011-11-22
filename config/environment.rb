# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
BiofabWeb::Application.initialize!


Mime::Type.register "application/xml", :sbol
