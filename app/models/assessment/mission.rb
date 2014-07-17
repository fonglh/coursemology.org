class Assessment::Mission < ActiveRecord::Base
  acts_as_paranoid
  is_a :assessment, as: :as_assessment, class_name: "Assessment"

  include Rails.application.routes.url_helpers

  attr_accessible :close_at
  attr_accessible :single_question,
                  :file_submission,
                  :file_submission_only,
                  :comment_per_qn
  attr_accessible :display_mode_id,
                  :dependent_id

  validates_with DateValidator, fields: [:open_at, :close_at]

  belongs_to  :display_mode, class_name: "AssignmentDisplayMode", foreign_key: "display_mode_id"

  belongs_to  :dependent_on, class_name: "Assessment", foreign_key: "dependent_id"

  # has_many :questions, through: :asm_qns, source: :qn, source_type: "Question", dependent: :destroy
  # has_many :coding_questions, through: :asm_qns, source: :qn, source_type: "CodingQuestion", dependent: :destroy

  def attach_files(files)
    files.each do |id|
      file = FileUpload.where(id: id).first
      if file
        file.owner = self
        file.save
      end
    end
  end

  def total_exp
    exp
  end

  #TODO
  def can_start?(curr_user_course)
    if open_at > Time.now
      return  false
    end
    if dependent_on
      sbm = assessment.submissions.where(assessment_id: dependent_id, std_course_id: curr_user_course).first
      if !sbm || sbm.attempting?
        return false
      end
    end
    true
  end

  def get_path
    course_assessment_mission_path(self.course, self)
  end

  def missions_dep_on_published
    missions_dependent_on.where(publish:true)
  end

  def current_exp
    exp
  end

  #TODO
  def mark_refresh_autograding
    # Thread.new {
    #   submissions.each do |s|
    #     s.submission_gradings.each do |sg|
    #       sg.update_attribute(:autograding_refresh, true)
    #     end
    #   end
    # }
  end

  #TODO

  #TODO

  alias_method :sbms, :submissions
end
