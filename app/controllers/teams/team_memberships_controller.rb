# app/controllers/teams/team_memberships_controller.rb
class Teams::TeamMembershipsController < AuthorizedController
  before_action :set_team
  load_and_authorize_resource :team

  def new
    @membership = UserTeam.new
    @users = User.where.not(id: @team.user_ids)
  end

  def create
    @membership = UserTeam.new(team_membership_params)
    @membership.team = @team
    if @membership.save
      redirect_to @team, notice: "User was added to the team."
    else
      @users = User.where.not(id: @team.user_ids)
      render :new
    end
  end

  def destroy
    @membership = @team.user_teams.find(params[:id])
    @membership.destroy
    redirect_to @team, notice: "User was removed from the team."
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  def team_membership_params
    params.require(:user_team).permit(:user_id)
  end
end
