module ApplicationHelper

  def absolute_url_for(*args)
    relative_url = url_for(*args)

    port = Settings['port']

    if ((Settings['protocol'] == 'http') && (port == 80)) || ((Settings['protocol'] == 'https') && (port == 443))
      port = ''
    else
      port = ":#{port}"
    end

    "#{Settings['protocol']}://#{Settings['hostname']}#{port}#{Settings['url_prefix'] || ''}#{relative_url}"

  end

end
