class CommentMailer < ApplicationMailer
    default from: "mash-it@mashiverse.com"

    def reply_notification
        @comment = params[:comment]
        @recipient = params[:recipient]
        @post = @comment.post

        mail(
            to: @recipient.email,
            subject: "#{@comment.user.username} replied to your comment on: #{@post.title}"
        )
    end

    def post_comment_notification
        @comment = params[:comment]
        @recipient = params[:recipient]
        @post = @comment.post

        mail(
            to: @recipient.email,
            subject: "#{@comment.user.username} commented on your post: #{@post.title}"
        )
    end
end
