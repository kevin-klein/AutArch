module ApplicationHelper
  def react_component(name, props = {})
    content_tag(
      :div,
      nil,
      data: {
        react_component: name,
        props: props.to_json
      }
    )
  end
end
