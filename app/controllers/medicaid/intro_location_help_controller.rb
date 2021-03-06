module Medicaid
  class IntroLocationHelpController < MedicaidStepsController
    private

    def skip?
      michigan_resident?
    end

    def michigan_resident?
      current_application&.michigan_resident?
    end
  end
end
