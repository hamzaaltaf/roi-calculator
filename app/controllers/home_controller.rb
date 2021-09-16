class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  extend ActionView::Helpers::NumberHelper
  include ActionView::Helpers::NumberHelper

  
  def show
  end

  def calculate
    error, field, total = false, "", 0
    working_hours = 8
    avg_cost_ex = 200
    avg_cost_ac = 400
    avg_cost_freezer = 300
    avg_cost_chiller = 400
    total_cost = avg_cost_ex  + avg_cost_ac + avg_cost_freezer + avg_cost_chiller
    # calculations part 1
    wage = params[:wage].to_i
    equipments = params[:pieces].to_i
    rounds = params[:manual_checks].to_i
    exhausts = params[:exhausts].to_i
    ac = params[:aircons].to_i
    chillers = params[:chillers].to_i
    freezers = params[:freezers].to_i
    issues = params[:issues].to_i
    error, field, total = true, '#roi__calc__issues', 0 if issues < 0
    error, field, total = true, '#roi__calc__wage', 0 if wage < 0
    error, field, total = true, '#roi__calc__pieces', 0 if equipments < 0
    error, field, total = true, '#roi__calc__manual_checks', 0 if rounds < 0
    error, field, total = true, '#roi__calc__exhausts', 0 if exhausts < 0
    error, field, total = true, '#roi__calc__aircons', 0 if ac < 0
    error, field, total = true, '#roi__calc__freezers', 0 if freezers < 0
    error, field, total = true, '#roi__calc__chillers', 0 if chillers < 0
    if error == false
      total_eq = exhausts + ac + freezers + chillers
      average_cost_per_eq = (total_cost.to_f/total_eq.to_f).to_f
      failure_probability = ((params[:issues].to_f/total_eq.to_f)).to_f.round(2)
      saving_1 = (failure_probability * average_cost_per_eq).to_f.ceil
      # calculations part 2
      time_to_check_one = 0.03
      saving_2 = 30*(rounds * equipments * time_to_check_one * wage).to_f.round(2)
      # calculations part 3
      hours_saved_for_exhaust = 3
      hours_saved_for_aircon = 2
      hours_saved_for_freezer = 3
      hours_saved_for_chiller = 4
      avg_ac_consumption = 3
      avg_ex_consumption = 2.5
      avg_consumption = 1
      terrif = 1.2
      exhaust_saving = exhausts * (hours_saved_for_exhaust * 30 * avg_ex_consumption * terrif)
      ac_saving = ac * (hours_saved_for_aircon * 30 * avg_ac_consumption * terrif)
      freezer_saving = freezers * (hours_saved_for_freezer * 30 * avg_consumption * terrif)
      chiller_saving = chillers * (hours_saved_for_chiller * 30 * avg_consumption * terrif)
      saving_3 = (exhaust_saving + ac_saving +  freezer_saving + chiller_saving).to_f.ceil
      total = ((saving_1 + saving_2 + saving_3) * 12).to_f.round(0)
      total = number_with_delimiter((total), :delimiter => ',') if total > 0
    end
    respond_to do |format|
      format.json { render json: { error: error, field: field, total: total, error_field: field + "__error" }}
    end
    
  end
end
