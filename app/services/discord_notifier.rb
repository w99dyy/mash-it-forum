class DiscordNotifier
    def self.post_created(post)
      webhook_url = ENV["DISCORD_WEBHOOK_URL"]
      return unless webhook_url.present?

      require "net/http"
      require "uri"
      
      # Fetch image first from Cloudinary
      image_url = nil
      if post.body.embeds.any?
        image_url = Cloudinary::Utils.cloudinary_url(post.body.embeds.first.key)
      end
          
        message = {
        content: "**New post on Mashit Forum**",
        embeds: [{
        title: post.title,
        url: "#{ENV['APP_URL']}/t/#{post.topic.slug}/p/#{post.slug}",
        author: {
          name: post.user.username
        },

        fields: [
          {
          name: "Topic:",
          value: "[#{post.topic.title}](#{ENV['APP_URL']}/t/#{post.topic.slug})"
        },

        {
          name: "Content:",
          # Added gsub to remove file name if there is attachments
          value: post.body.to_plain_text.gsub(/\[.*?\.(gif|jpg|jpeg|png)\]/i, '').truncate(100)
        }
      ],
      
      footer: {
        text: "Mash-it project.",
        url: "https://mash-it.io/mashers"
      },
      timestamp: Time.now.utc.iso8601

        }]
}
      # Add Image to embed if it exists
      if image_url
        message[:embeds][0][:image] = { url: image_url }
      end

      uri = URI.parse(webhook_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request.body = message.to_json

      Thread.new { http.request(request) rescue nil }
    end
end
