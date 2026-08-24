package com.ironexx.tv;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {
    private ListView listView;
    private ArrayAdapter<Machine> adapter;
    private int focusedIndex = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        List<Machine> machines = new ArrayList<>();
        machines.add(new Machine("Excavadora CAT 320", "$3,200,000", "Sucursal Centro"));
        machines.add(new Machine("Retroexcavadora", "$1,850,000", "Sucursal Centro"));
        machines.add(new Machine("Bulldozer D6", "$4,100,000", "Sucursal Norte"));
        machines.add(new Machine("Grúa móvil", "$5,200,000", "Sucursal Norte"));
        machines.add(new Machine("Camión de volteo", "$5,800,000", "Sucursal Sur"));
        machines.add(new Machine("Soldadora", "$420,000", "Sucursal Sur"));

        listView = findViewById(R.id.machineList);
        adapter = new MachineAdapter(machines);
        listView.setAdapter(adapter);
        listView.setOnItemClickListener((parent, view, position, id) -> {
            focusedIndex = position;
            updateSelection();
        });

        listView.setOnKeyListener((v, keyCode, event) -> {
            if (event.getAction() == KeyEvent.ACTION_DOWN) {
                switch (keyCode) {
                    case KeyEvent.KEYCODE_DPAD_DOWN:
                        focusedIndex = Math.min(focusedIndex + 1, adapter.getCount() - 1);
                        updateSelection();
                        return true;
                    case KeyEvent.KEYCODE_DPAD_UP:
                        focusedIndex = Math.max(focusedIndex - 1, 0);
                        updateSelection();
                        return true;
                    case KeyEvent.KEYCODE_DPAD_LEFT:
                        focusedIndex = Math.max(focusedIndex - 1, 0);
                        updateSelection();
                        return true;
                    case KeyEvent.KEYCODE_DPAD_RIGHT:
                        focusedIndex = Math.min(focusedIndex + 1, adapter.getCount() - 1);
                        updateSelection();
                        return true;
                }
            }
            return false;
        });

        listView.post(() -> {
            listView.setSelection(focusedIndex);
            updateSelection();
        });
    }

    private void updateSelection() {
        listView.setSelection(focusedIndex);
        int count = listView.getChildCount();
        for (int i = 0; i < count; i++) {
            View child = listView.getChildAt(i);
            if (child != null) {
                boolean selected = i == (focusedIndex - listView.getFirstVisiblePosition());
                child.setBackgroundColor(selected
                        ? ContextCompat.getColor(this, R.color.gold)
                        : ContextCompat.getColor(this, R.color.panel));
            }
        }
    }

    private static class Machine {
        final String name;
        final String price;
        final String branch;

        Machine(String name, String price, String branch) {
            this.name = name;
            this.price = price;
            this.branch = branch;
        }
    }

    private class MachineAdapter extends ArrayAdapter<Machine> {
        MachineAdapter(List<Machine> machines) {
            super(MainActivity.this, 0, machines);
        }

        @NonNull
        @Override
        public View getView(int position, View convertView, @NonNull ViewGroup parent) {
            View row = convertView;
            if (row == null) {
                row = LayoutInflater.from(getContext()).inflate(R.layout.item_machine, parent, false);
            }

            Machine machine = getItem(position);
            TextView name = row.findViewById(R.id.machineName);
            TextView price = row.findViewById(R.id.machinePrice);
            TextView branch = row.findViewById(R.id.machineBranch);
            ImageView icon = row.findViewById(R.id.machineIcon);

            name.setText(machine.name);
            price.setText(machine.price);
            branch.setText(machine.branch);
            icon.setImageResource(R.drawable.ic_machine);

            if (position == focusedIndex) {
                row.setBackgroundColor(ContextCompat.getColor(getContext(), R.color.gold));
            } else {
                row.setBackgroundColor(ContextCompat.getColor(getContext(), R.color.panel));
            }

            return row;
        }
    }
}
