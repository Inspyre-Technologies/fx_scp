module FXscp
  module Cleanup
    
    def switch(task)
      LOG.info('STARTING CLEANUP JOB')
      LOG.debug('Checking to see if conflicting fields exist...')
      
      case task
      
      when 'remote'
        LOG.debug('Received task to cleanup for new remote pops')
        LOG.debug('Checking to see if remote pops exist')
        LOG.debug('No remote pops found') if !is_active?
      end
    end
  end
end
