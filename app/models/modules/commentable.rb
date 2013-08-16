module Commentable
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def self.included(base)
    base.class_eval do
      has_many :comment_subscriptions, as: :topic, dependent: :destroy
      has_many :user_courses, through: :comment_subscriptions
    end
  end

  def get_subscribed_user_courses
    raise NotImplementedError
  end

  def pending?
    if self.pending_comments
      self.pending_comments.pending?
    else
      false
    end
  end

  def set_pending_comments(pending)
    if self.respond_to?(:pending_comments)
      # TODO support pending comments for mcq & coding question
      if self.pending_comments
        self.pending_comments.update_attribute(:pending, pending)
      else
        self.build_pending_comments(pending:pending).save
      end
    end
  end

  def notify_user(curr_user_course, comment, redirect_url)
    # notify everyone except the ones who made the comment
    user_courses = self.user_courses - [curr_user_course]
    user_courses.each do |uc|
      UserMailer.delay.new_comment(uc.user, comment, redirect_url)
    end
  end

  def comments_json(curr_user_course = nil)
    responds = []

    self.comments.each do |c|
      puts curr_user_course.to_json
      edit  = false
      if curr_user_course and (curr_user_course.is_staff? || curr_user_course == c.user_course)
        edit = true
      end
      resp = c.as_json
      resp[:edit] = edit
      responds.append(resp)
    end
    responds
  end
end
