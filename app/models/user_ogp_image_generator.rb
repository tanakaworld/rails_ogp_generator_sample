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
    image.new_image(1200, 630) do
      self.background_color = '#e5e5e5'
    end

    draw = Magick::Draw.new
    draw.gravity = Magick::CenterGravity
    draw.font = Rails.root.join('app', 'assets', 'fonts', 'NotoSansCJKjp-Medium.otf').to_s
    draw.fill = 'white'

    # avatar
    avatar_image = Magick::Image.from_blob(open(avatar_path).read).first
    avatar_image = avatar_image.resize(320, 320)
    avatar_image = make_circle_mask(avatar_image, 320)
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

  private

  def make_circle_mask(image, size)
    circle_image = Magick::Image.new(size, size)
    draw = Magick::Draw.new

    # ref: https://rmagick.github.io/draw.html#circle
    draw.circle(size / 2, size / 2, size / 2, 0)
    draw.draw(circle_image)
    mask = circle_image.blur_image(0, 1).negate
    mask.matte = false

    image.matte = true
    image.composite!(mask, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)

    image
  end
end