class UserOgpImageGenerator
  include Magick

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def generate
    user_id = @user.id
    user_name = @user.name
    avatar_path = @user.avatar.present? ?
                      user.avatar.url
                      : ActionController::Base.helpers.image_path('default-avatar.png', host: 'http://localhost:3000')

    image = Magick::ImageList.new
    image.new_image(1200, 630)

    draw = Magick::Draw.new
    draw.gravity = Magick::CenterGravity
    draw.font = Rails.root.join('app', 'assets', 'fonts', 'NotoSansCJKjp-Medium.otf').to_s
    draw.fill = 'white'

    # profile icon
    avatar_image = Magick::Image.from_blob(open(avatar_path).read).first
    avatar_image = avatar_image.resize(320, 320)
    image.composite!(avatar_image, Magick::CenterGravity, 0, -80, Magick::OverCompositeOp)

    # name
    if user_name.present?
      draw.pointsize = 58
      draw.annotate(image, 0, 0, 0, 155, user_name) {
        self.fill = '#333'
      }
    end

    dist_dir = "#{Rails.root.join('tmp', 'ogp_image')}"
    Dir.mkdir(dist_dir) unless File.exists?(dist_dir)
    dist_path = "#{dist_dir}/#{user_id}-#{user_name}.png"
    image.write(dist_path)
    dist_path
  end
end