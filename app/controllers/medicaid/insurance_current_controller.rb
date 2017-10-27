# frozen_string_literal: true

module Medicaid
  class InsuranceCurrentController < MedicaidStepsController
    private

    def after_successful_update_hook
      if single_member_household?
        current_application.primary_member.update!(member_attrs)
      end
    end

    def member_attrs
      { insured: step_params[:anyone_insured] }
    end
  end
end
