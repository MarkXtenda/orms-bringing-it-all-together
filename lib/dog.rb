

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name: 'name', breed: 'breed', id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table 
        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed text
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES
        (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL 
        SELECT * FROM dogs WHERE id = ?
        SQL
        dog_arr = DB[:conn].execute(sql, id)[0]
        dog = self.new(id: dog_arr[0], name: dog_arr[1], breed: dog_arr[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        resulted_array = DB[:conn].execute(sql, name, breed)
        if resulted_array.empty?
            self.create(name: name, breed: breed)
        else 
            self.new_from_db(resulted_array[0])
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        resulted_array = DB[:conn].execute(sql, name)[0]
        new_dog = self.new(id: resulted_array[0], name: resulted_array[1], breed: resulted_array[2])
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
