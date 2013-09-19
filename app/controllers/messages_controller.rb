class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only: :destroy

  def index
    @messages = current_user.messages.conversations
    #Pusher['private-'+current_user.id.to_s].trigger('new_message', {from: current_user.username})
  end

  def new
    @message = ActsAsMessageable::Message.new
  end

  #def create
  #	if User.find_by_username(params[:message][:to]) != nil
  #    @to = User.find_by_username(params[:message][:to])
  #    @body = params[:message][:body]
  #    if !current_user.messages.are_to(@to).blank?
  #      @old_message = current_user.messages.are_to(@to).last
  #      @message = current_user.reply_to(@old_message, @body)
  #      redirect_to message_path(@old_message)
  #    else
  #      @message = current_user.send_message(@to, @body)
  #      if @message.errors.blank?
  #        flash[:success] = "Message sent"
  #        redirect_to messages_path
  #      else
  #        flash[:error] = "Message not sent"
  #        redirect_to new_message_path
  #      end
  #    end
  #  else
  #    flash.now[:error] = "User not found"
  #    render "new"
  #   end
  #end

  def create
    if User.find_by_username(params[:message][:to]) != nil
      @to = User.find_by_username(params[:message][:to])
      @body = params[:message][:body]
      if !current_user.messages.are_to(@to).blank?
        @old_message = current_user.messages.are_to(@to).last
        @message = current_user.reply_to(@old_message, @body)
        if (@message.errors.blank?)
          Pusher['private-'+current_user.id.to_s].trigger('new_message', {from: current_user.username, message_body: @message.body, message_time: @message.created_at.strftime("%H:%M")})
        end
        redirect_to message_path(@old_message)
      elsif !current_user.messages.are_from(@to).blank?
        @old_message = current_user.messages.are_from(@to).last
        @message = current_user.reply_to(@old_message, @body)
        if (@message.errors.blank?)
          Pusher['private-'+current_user.id.to_s].trigger('new_message', {from: current_user.username, message_body: @message.body, message_time: @message.created_at.strftime("%H:%M")})
        end
        redirect_to message_path(@old_message)
      else
        @message = current_user.send_message(@to, @body)
        if (@message.errors.blank?)
          flash[:success] = "Message sent"
          Pusher['private-'+current_user.id.to_s].trigger('new_message', {from: current_user.username, message_body: @message.body, message_time: @message.created_at.strftime("%H:%M")})
          redirect_to messages_path
        else
          flash[:error] = "Message not sent"
          redirect_to new_message_path
        end
      end
    else
      flash.now[:error] = "User not found"
      render 'new'
    end
  end

  #def show
  #  @message = current_user.messages.find(params[:id])
  #  @conversation = @message.conversation.reverse
  #end

  def show
    @message = current_user.messages.find(params[:id])
    @received_conversation = @message.conversation.where(received_messageable_id: current_user.id.to_s).where(recipient_delete: false)
    @sent_conversation = @message.conversation.where(sent_messageable_id: current_user.id.to_s).where(sender_delete: false)
    @all_conversation = @received_conversation + @sent_conversation
    @conversation = @all_conversation.sort_by { |obj| obj.created_at }
  end

  def reply
    @message = current_user.messages.find(params[:id])
    @body = params[:acts_as_messageable_message][:body]
    current_user.reply_to(@message, @body)
    redirect_to message_path(@message)
  end
  
  # destroy method
  # if ancestry =/= nil then take ancestry + / + message.id
  #def destroy
  #  @conversation_delete = current_user.messages.where(ancestry: @message.id.to_s)
  #  @conversation_delete.each do |message|
  #    current_user.delete_message(message)
  #  end
  #  current_user.delete_message(@message)
  #  flash[:success] = "Message deleted"
  #  redirect_to messages_path
  #end

  def destroy
    @message.conversation.each do |message|
      current_user.delete_message(message)
    end
    flash[:success] = "Message deleted"
    redirect_to messages_path
  end

  private
    def correct_user
      @message = current_user.messages.find_by(id: params[:id])
      redirect_to messages_path if @message.nil?
    end
end