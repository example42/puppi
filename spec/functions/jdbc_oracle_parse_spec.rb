require 'spec_helper'

describe 'jdbc_oracle_parse' do

  describe 'Test Oracle JDBC Uri Components parsing' do
    it 'should return correct scheme' do
      should run.with_params('jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521/dbname','scheme').and_return('oracle') 
    end
    it 'should return correct client' do
      should run.with_params('jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521/dbname','client').and_return('thin') 
    end
    it 'should return correct user' do
      should run.with_params('jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521/dbname','user').and_return('dblogin') 
    end
    it 'should return correct password' do
      should run.with_params('jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521/dbname','password').and_return('Pass0') 
    end
    it 'should return correct host' do
      should run.with_params('jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521/dbname','host').and_return('oe-db-01.example.local') 
    end
    it 'should return correct port' do
      should run.with_params('jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521/dbname','port').and_return('1521') 
    end
    it 'should return correct db' do
      should run.with_params('jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521/dbname','db').and_return('dbname') 
    end

  end

end

