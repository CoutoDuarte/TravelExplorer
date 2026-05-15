package Connection.Classes;

import java.util.ArrayList;
import java.util.List;

public class FlightsSearchResult {
    public List<VooInfo> voosIda = new ArrayList<>();
    public List<VooInfo> voosRegresso = new ArrayList<>();

    public List<VooInfo> voosIdaCompat() {
        return voosIda;
    }
}
