class UserOgpImage < ApplicationRecord
  belongs_to :user

  mount_uploader :image, UserOgpImageUploader

  validates :user, presence: true

  def url
    image.url
  end
end