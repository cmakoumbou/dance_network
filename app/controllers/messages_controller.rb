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
  #      redirect_to chat_message_path(@old_message)
  #    else
  #      @message = current_user.send_message(@to, @body)
  #      if @message.errors.blank?
  #        flash[:success] = "Message sent"
  #        redirect_to messages_path
  #      else
  #        flash[:error] = "Message not sent"
  #        redirect_to new_chat_message_path
  #      end
  #    end
  #  else
  #    flash.now[:error] = "User not found"
  #    render "new"
  #   end
  #end

  def create
    if User.find_by_username(params[:message][:to]) != nil && User.find_by_username(params[:message][:to]) != current_user
      @to = User.find_by_username(params[:message][:to])
      @body = params[:message][:body]
      if !current_user.messages.are_to(@to).blank?
        @old_message = current_user.messages.are_to(@to).last
        @message = current_user.reply_to(@old_message, @body)
        if (@message.errors.blank?)
          Pusher['private-'+@to.id.to_s].trigger('reply_message', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            message_id: @message.id.to_s, from: current_user.username, to: @message.to.username, message_body: @message.body, message_time: @message.created_at.strftime("%H:%M")})
          Pusher['private-'+@to.id.to_s].trigger('message_notification', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            from: current_user.username, total_message_count: @to.messages.are_to(@to).unreaded.count, message_count: @to.messages.are_from(current_user).unreaded.count})
        end
        redirect_to chat_message_path(@old_message)
      elsif !current_user.messages.are_from(@to).blank?
        @old_message = current_user.messages.are_from(@to).last
        @message = current_user.reply_to(@old_message, @body)
        if (@message.errors.blank?)
          Pusher['private-'+@to.id.to_s].trigger('reply_message', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            message_id: @message.id.to_s, from: current_user.username, to: @message.to.username, message_body: @message.body, message_time: @message.created_at.strftime("%H:%M")})
          Pusher['private-'+@to.id.to_s].trigger('message_notification', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            from: current_user.username, total_message_count: @to.messages.are_to(@to).unreaded.count, message_count: @to.messages.are_from(current_user).unreaded.count})
        end
        redirect_to chat_message_path(@old_message)
      elsif !@to.messages.are_from(current_user).blank?
        @old_message = @to.messages.are_from(current_user).last
        @message = current_user.reply_to(@old_message, @body)
        if (@message.errors.blank?)
          Pusher['private-'+@to.id.to_s].trigger('reply_message', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            message_id: @message.id.to_s, from: current_user.username, to: @message.to.username, message_body: @message.body, message_time: @message.created_at.strftime("%H:%M")})
          Pusher['private-'+@to.id.to_s].trigger('message_notification', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            from: current_user.username, total_message_count: @to.messages.are_to(@to).unreaded.count, message_count: @to.messages.are_from(current_user).unreaded.count})
        end
        redirect_to chat_message_path(@message)
      else
        @message = current_user.send_message(@to, @body)
        if (@message.errors.blank?)
          flash[:success] = "Message sent"
          Pusher['private-'+@to.id.to_s].trigger('new_message', {from: current_user.username})
          Pusher['private-'+@to.id.to_s].trigger('message_notification', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            from: current_user.username, total_message_count: @to.messages.are_to(@to).unreaded.count, message_count: @to.messages.are_from(current_user).unreaded.count})
          redirect_to messages_path
        else
          flash[:error] = "Message not sent"
          redirect_to new_message_path
        end
      end
    elsif User.find_by_username(params[:message][:to]) == current_user
      flash.now[:error] = "Can't message yourself"
      render 'new'
    else
      flash.now[:error] = "User not found"
      render 'new'
    end
  end

  #def show
  #  @message = current_user.messages.find(params[:id])
  #  @conversation = @message.conversation.reverse
  #end

  def chat
    @message = current_user.messages.find(params[:id])
    @received_conversation = @message.conversation.where(received_messageable_id: current_user.id.to_s).where(recipient_delete: false)
    @received_conversation.each do |message|
      message.mark_as_read
    end
    @sent_conversation = @message.conversation.where(sent_messageable_id: current_user.id.to_s).where(sender_delete: false)
    @all_conversation = @received_conversation + @sent_conversation
    @conversation = @all_conversation.sort_by { |obj| obj.created_at }
  end

  def reply
    @old_message = current_user.messages.find(params[:id])
    @body = params[:acts_as_messageable_message][:body]
    @message = current_user.reply_to(@old_message, @body)
    if @old_message.to == current_user
      Pusher['private-'+@old_message.from.id.to_s].trigger('reply_message', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            message_id: @message.id.to_s, from: current_user.username, to: @message.to.username, message_body: @message.body, message_time: @message.created_at.strftime("%H:%M")})
      Pusher['private-'+@old_message.from.id.to_s].trigger('message_notification', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
        from: current_user.username, total_message_count: @old_message.from.messages.are_to(@old_message.from).unreaded.count, message_count: @old_message.from.messages.are_from(current_user).unreaded.count})
      if @old_message.from.messages.are_from(current_user).count == 1
        Pusher['private-'+@old_message.from.id.to_s].trigger('new_message', {from: current_user.username})
      end
    else
      Pusher['private-'+@old_message.to.id.to_s].trigger('reply_message', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
            message_id: @message.id.to_s, from: current_user.username, to: @message.to.username, message_body: @message.body, message_time: @message.created_at.strftime("%H:%M")})
      Pusher['private-'+@old_message.to.id.to_s].trigger('message_notification', {conversation: @message.conversation.order("created_at").last.body.truncate(30, separator: ' '), 
        from: current_user.username, total_message_count: @old_message.to.messages.are_to(@old_message.to).unreaded.count, message_count: @old_message.to.messages.are_from(current_user).unreaded.count})
      if @old_message.to.messages.are_from(current_user).count == 1
        Pusher['private-'+@old_message.to.id.to_s].trigger('new_message', {from: current_user.username})
      end
    end
    redirect_to chat_message_path(@old_message)
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