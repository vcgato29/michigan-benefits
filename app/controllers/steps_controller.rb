class StepsController < ApplicationController
  include ApplicationHelper

  layout 'step'

  def allowed
    {
      show: :member,
      update: :member
    }
  end

  def show # TODO: should be "edit"
    @app = current_app
    @step = find_step
    respond_with @step
  end

  def update
    @step = find_step
    @step.update(step_params)

    if @step.valid?
      redirect_to path_to_step(@step.next)
    else
      render :show
    end
  end

  private

  def find_step
    Step.find(params[:id], current_app, params.slice(*%w[member_id]))
  end

  def step_params
    if params.has_key?(:step)
      if params["step"].has_key?("household_members")
        this_step_params = params.require(:step)
        this_step_params.permit(
          household_members: [
            :in_college,
            :is_disabled
          ]
        )
      else
        this_step_params = params.require(:step)
        consolidate_multiparam_date_attrs!(this_step_params)
        this_step_params.permit(@step.questions.keys)
      end
    else
      {}
    end
  end

  def consolidate_multiparam_date_attrs!(params)
    multiparam_date_attrs = Hash.new
    delete_params = []

    params.each do |key, val|
      # first capture is attr name, second is order
      multiparam_regex = /(\w+)\((\d)i\)/

      if key =~ /\(\di\)/
        puts key
        delete_params << key
        attr_name = key[multiparam_regex, 1]
        order = key[multiparam_regex, 2].to_i

        multiparam_date_attrs[attr_name] ||= []
        multiparam_date_attrs[attr_name][order] = val
      end
    end

    delete_params.each { |param| params.delete(param) }

    multiparam_date_attrs.each do |key, vals|
      params[key] = Date.new(*vals.compact.map(&:to_i))
    end
  end
end