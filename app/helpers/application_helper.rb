module ApplicationHelper
  def render_user_avatar(user)
    avatar_url = user.avatar.present? ? url_for(user.avatar.url) : image_url('default-avatar.png')

    content_tag :img,
                nil,
                src: avatar_url,
                width: 30, height: 30,
                alt: user.name
  end

  def render_user_ogp_image(user, height: 30)
    ogp_image_url = user.user_ogp_image.present? ? url_for(user.user_ogp_image.image.url) : image_url('default-ogp.png')

    content_tag :img,
                nil,
                src: ogp_image_url,
                height: height,
                alt: user.name
  end
end
