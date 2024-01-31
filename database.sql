CREATE TABLE users (
  id uuid REFERENCES auth.users on delete cascade not null primary key,
  email TEXT UNIQUE,
  phone TEXT UNIQUE,
  username TEXT UNIQUE,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE,
  website TEXT,
  CONSTRAINT username_length check (char_length(username) >= 3)
);

CREATE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, phone)
  VALUES (new.id, new.email, new.phone);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY definer;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR each ROW EXECUTE PROCEDURE public.handle_new_user();

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    chat_room_id UUID,
    sender_user_id UUID NOT NULL,
    receiver_user_id UUID NOT NULL,
    content TEXT,
    attachment_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (sender_user_id) REFERENCES users(id), 
    FOREIGN KEY (receiver_user_id) REFERENCES users(id)
);

CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    last_message_id UUID,
    unread_count int
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (last_message_id) REFERENCES messages(id) 
);

CREATE TABLE chat_room_participants (
    chat_room_id UUID,
    participant_id UUID,
    PRIMARY KEY (chat_room_id, participant_id),
    FOREIGN KEY (chat_room_id) REFERENCES chat_rooms(id),
    FOREIGN KEY (participant_id) REFERENCES users(id)
);

CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    message_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL,
    attachment_url TEXT NOT NULL,
    FOREIGN KEY (message_id) REFERENCES messages(id) 
);

ALTER TABLE messages
ADD FOREIGN KEY (attachment_id) REFERENCES attachments(id);

ALTER TABLE messages
ADD FOREIGN KEY (chat_room_id) REFERENCES chat_rooms(id);


-- Insert sample data (replace the user ids first)
INSERT INTO chat_rooms (id, last_message_id, unread_count) 
VALUES 
('8d162274-6cb8-4776-815a-8e721ebfb76d', NULL, 0);

INSERT INTO messages (id, chat_room_id, sender_user_id, receiver_user_id, content, created_at) 
VALUES 
('de120f3a-dbca-4330-9e2e-18b55a2fb9e5', '8d162274-6cb8-4776-815a-8e721ebfb76d', 'cfd843f1-411e-4470-97c3-569beb9d6ad1', 'd10ee914-ab9a-4392-a4ee-3c021d5f8dd9', 'Hey! I am good, thanks.', '2023-12-01 01:00:10'),
('29829a84-30b9-47e9-b6df-518519843f7d', '8d162274-6cb8-4776-815a-8e721ebfb76d', 'd10ee914-ab9a-4392-a4ee-3c021d5f8dd9', 'cfd843f1-411e-4470-97c3-569beb9d6ad1', 'Hey! How are you?', '2023-12-01 01:00:00');


INSERT INTO chat_room_participants (chat_room_id, participant_id) 
VALUES 
('8d162274-6cb8-4776-815a-8e721ebfb76d', 'cfd843f1-411e-4470-97c3-569beb9d6ad1'),
('8d162274-6cb8-4776-815a-8e721ebfb76d', 'd10ee914-ab9a-4392-a4ee-3c021d5f8dd9');

UPDATE chat_rooms 
SET last_message_id = 'de120f3a-dbca-4330-9e2e-18b55a2fb9e5'
WHERE id = '8d162274-6cb8-4776-815a-8e721ebfb76d';