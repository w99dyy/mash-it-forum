class DiscordNotifier
    def self.post_created(post)
      webhook_url = ENV["DISCORD_WEBHOOK_URL"]
      return unless webhook_url.present?

      require "net/http"
      require "uri"

        message = {
        content: "**New post on Mashit Forum**",
        embeds: [{
        title: post.title,
        url: "#{ENV['APP_URL']}/topics/#{post.topic.slug}/posts/#{post.slug}",
        author: {
          name: post.user.username
        },

        fields: [
          {
          name: "Topic:",
          value: "[#{post.topic.title}](#{ENV['APP_URL']}/topics/#{post.topic.slug})"
        },

        {
          name: "Content:",
          value: post.body.to_plain_text.truncate(100)
        }
      ],
      footer: {
        text: "Mash-it project.",
        url: "https://mash-it.io/mashers"
      },
      timestamp: Time.now.utc.iso8601

        }]
}

      uri = URI.parse(webhook_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request.body = message.to_json

      Thread.new { http.request(request) rescue nil }
    end
end
