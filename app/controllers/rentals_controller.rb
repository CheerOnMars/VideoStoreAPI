class RentalsController < ApplicationController

  def checkout
    movie = Movie.find_by(id: params[:rental][:movie_id])
    customer = Customer.find_by(id: params[:rental][:customer_id])
    if movie.nil? || customer.nil?
      render json: { ok: false }, status: :bad_request
    else
      if movie.available_inventory > 0
        rental = Rental.create(movie_id: params[:rental][:movie_id], customer_id: params[:rental][:customer_id], returned?: false, checkout_date: Date.today)
        if rental
          render json: rental.as_json(), status: :ok
        else
          render json: { ok: false, errors: rental.errors },
          status: :bad_request
        end
      else
        render json: { ok: false}, status: :bad_request # Todo: look up to see if better status
      end
    end
  end

  def checkin
    rental = Rental.where(movie_id: params[:rental][:movie_id], customer_id: params[:rental][:customer_id], returned?: false )
    # rental = Rental.find_by(params[:id])
    if rental.empty?
      render json: { ok: false }, status: :no_content
    else
      rental.update(returned?: true)
      render json: rental.as_json(), status: :ok
    end
  end

  def overdue
    rentals = Rental.get_overdue
    # if params[:sort] == "title"
    #   rentals.order(:movie_id.title).paginate(page: params[:p], per_page: params[:n])
    # elsif params[:sort] == "name"
    #   rentals.order(:name).paginate(page: params[:p], per_page: params[:n])
    # elsif params[:sort] == "checkout_date"
    #   rentals.order(:checkout_date).paginate(page: params[:p], per_page: params[:n])
    # elsif params[:sort] == "due_date"
    #   rentals.order(:checkout_date).paginate(page: params[:p], per_page: params[:n])
    # else
    #   rentals
    # end
    render json: rentals.as_json(), status: :ok
  end

  private

  def rental_params
    return params.permit(:customer_id, :movie_id)
  end
end
