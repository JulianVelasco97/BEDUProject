public class InventarioRest {

	public Integer statusCode;
	public Body body;

	public class Body {
		public List<Inventory> Inventory;
	}

	public class Inventory {
		public String name;
		public String ProductID;
		public Integer Quan;
		public Integer BlockedQuan;
	}

	
	public static InventarioRest parse(String json) {
		return (InventarioRest) System.JSON.deserialize(json, InventarioRest.class);
	}
}