module PushType
  class Inquiry < ActiveRecord::Base

    include PushType::Customizable

    default_scope { order(:name) }

    def initials
      chunks = name ? name.split(' ') : []
      chunks.slice!(1..-2)
      chunks.map { |n| n[0] }.join.upcase
    end


    def gravatar_url(size = 200)
      gravatar = Digest::MD5::hexdigest(email).downcase
      url = "http://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
    end

  end
end
