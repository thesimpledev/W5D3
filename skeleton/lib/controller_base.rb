require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
    @session = Session.new(req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise "Render twice"
    end
    @res.status = 302
    @res['location'] = url
    @session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise "Render twice"
    else
      @res.write(content)
      @session.store_session(@res)
      @res['Content-Type'] = content_type
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    # base_path = File.dirname(__FILE__).gsub!(/\/dirs/, "")
    base_path = "/Users/appacademy/Desktop/W5D3/skeleton"
    controller_view_path = self.class.to_s.downcase.gsub("controller", "_controller")
    view_path = File.join(base_path, 'views', controller_view_path, "#{template_name}.html.erb")
    content = File.read(view_path)
    erb_code = ERB.new(content).result(binding)
    render_content(erb_code, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

