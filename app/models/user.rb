class User < ApplicationRecord
  has_one :user_ogp_image, dependent: :destroy

  mount_uploader :avatar, UserAvatarUploader

  after_save :generate_ogp_image, if: :ogp_image_info_changed?

  def ogp_image_info_changed?
    name_changed? || avatar_changed?
  end

  def generate_ogp_image
    ogp_image_generator = UserOgpImageGenerator.new(self)
    file_path = ogp_image_generator.generate

    tmp_user_ogp_image = user_ogp_image.present? ? user_ogp_image : UserOgpImage.new(user: self)
    tmp_user_ogp_image.image = File.open(file_path)
    tmp_user_ogp_image.save!
  end
end
