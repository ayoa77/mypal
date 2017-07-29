# == Schema Information
#
# Table name: newsletters
#
#  id         :integer          not null, primary key
#  subject    :string(191)
#  intro      :string(191)
#  content    :text(16777215)
#  sent       :boolean          default("0")
#  created_at :datetime
#  updated_at :datetime
#

class Newsletter < ActiveRecord::Base

  validates :subject, presence: true, uniqueness: true

  before_validation :sanitize_fields

  private

  def sanitize_fields
    self.subject = HTML::FullSanitizer.new.sanitize(self.subject) if self.subject.present?
    self.intro = HTML::FullSanitizer.new.sanitize(self.intro) if self.intro.present?
  end

end
