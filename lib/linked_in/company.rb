require 'cgi'

module LinkedIn
  module Company

    def csearch(options={})
      path = "/company-search"
      options = { :keywords => options } if options.is_a?(String)
      options = format_options_for_query(options)
      result_json = get(to_uri(path, options))
      Mash.from_json(result_json)
    end

  end
end

LinkedIn::Client.class_eval { include LinkedIn::Company }

