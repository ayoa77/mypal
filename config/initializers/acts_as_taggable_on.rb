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
 
  def setposition
    oldone = nil
    thisonesid = self.id
    thisonesposition = self.position
    oldones = ActsAsTaggableOn::Tag.where(position: thisonesposition)
    oldones = oldones.where.not(id:thisonesid)
    oldone = oldones.first
    
    unless oldone.nil? 
      oldone.position += 1
      oldone.save
      oldone.setposition
    end
      return 
  end

end
