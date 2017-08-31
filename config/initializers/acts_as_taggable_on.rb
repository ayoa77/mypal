# ActsAsTaggableOn.remove_unused_tags = true
ActsAsTaggableOn.force_lowercase = true

class ActsAsTaggableOn::Tag

  validates :name, length: {minimum: 3}
  validates :display_name, length: {minimum: 3}

  belongs_to :user
  belongs_to :request

  has_one :city_image, dependent: :destroy

  def populate
    self.update_columns(user_count: User.where(enabled: true).tagged_with(self.name, on: :tags).count)
  end

end
