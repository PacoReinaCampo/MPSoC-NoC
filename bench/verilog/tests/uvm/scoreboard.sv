class peripheral_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #(peripheral_sequence_item, peripheral_scoreboard) item_collect_export;
  peripheral_sequence_item item_q[$];
  `uvm_component_utils(peripheral_scoreboard)
  
  function new(string name = "peripheral_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    item_collect_export = new("item_collect_export", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  function void write(peripheral_sequence_item req);
    item_q.push_back(req);
  endfunction
  
  task run_phase (uvm_phase phase);
    peripheral_sequence_item scoreboard_item;
    forever begin
      wait(item_q.size > 0);
      
      if(item_q.size > 0) begin
        scoreboard_item = item_q.pop_front();
        $display("----------------------------------------------------------------------------------------------------------");
        if(scoreboard_item.ip1 + scoreboard_item.ip2 == scoreboard_item.out) begin
          `uvm_info(get_type_name, $sformatf("Matched: ip1 = %0d, ip2 = %0d, out = %0d", scoreboard_item.ip1, scoreboard_item.ip2, scoreboard_item.out), UVM_LOW);
        end
        else begin
          `uvm_error(get_name, $sformatf("NOT matched: ip1 = %0d, ip2 = %0d, out = %0d", scoreboard_item.ip1, scoreboard_item.ip2, scoreboard_item.out));
        end
        $display("----------------------------------------------------------------------------------------------------------");
      end
    end
  endtask
  
endclass