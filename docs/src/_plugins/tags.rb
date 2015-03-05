# https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers
class DescriptionTag < Liquid::Block
  def render(context)
    '<div class="description">' + super + '</div>'
  end
end

class ExampleTag < Liquid::Block
  def render(context)
    '<div class="example">' + super + '</div>'
  end
end

#Liquid::Template.register_tag('description', DescriptionTag)
#Liquid::Template.register_tag('example', ExampleTag)
