class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.order(start_time: :asc)
    @events = @events.where('start_time >= ?', params[:start_date]) if params[:start_date].present?
    @events = @events.where('end_time <= ?', params[:end_date]) if params[:end_date].present?
    @events = @events.where('name LIKE ?', "%#{params[:query]}%") if params[:query].present?
    @events = @events.page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.json { render json: @events }
    end
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = current_user.events.build(event_params)

    if event_conflicts?(@event)
      respond_to do |format|
        format.html {
          flash.now[:alert] = 'Event conflicts with existing events.'
          render :new
        }
        format.json { render json: { error: 'Event conflicts with existing events' }, status: :unprocessable_entity }
      end
    else
      if @event.save
        respond_to do |format|
          format.html { redirect_to @event, notice: 'Event was successfully created.' }
          format.json { render :show, status: :created, location: @event }
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  def update
    Rails.logger.debug "Params: #{event_params.inspect}"
    Rails.logger.debug "Checking for conflicts..."

    if event_conflicts?(@event, event_params)
      Rails.logger.debug "Conflict found."
      respond_to do |format|
        format.html {
          flash.now[:alert] = 'Event update conflicts with existing events.'
          render :edit
        }
        format.json { render json: { error: 'Event update conflicts with existing events' }, status: :unprocessable_entity }
      end
    elsif @event.update(event_params)
      Rails.logger.debug "Event updated successfully."
      respond_to do |format|
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      end
    else
      Rails.logger.debug "Event update failed: #{@event.errors.full_messages.join(', ')}"
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:start_time, :end_time, :title)
  end

  def event_conflicts?(event, new_params = nil)
    start_time = new_params ? new_params[:start_time] : event.start_time
    end_time = new_params ? new_params[:end_time] : event.end_time

   # Ensure start_time and end_time are valid timestamps
    return false if start_time.blank? || end_time.blank?

    Event.where(user_id: current_user.id)
         .where.not(id: event.id)
         .where('(start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?) OR (start_time >= ? AND end_time <= ?)',
                start_time, start_time, end_time, end_time, start_time, end_time)
         .exists?
  end

end
