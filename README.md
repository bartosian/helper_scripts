### Transacter usage

_Below is an example of how you can use transacter.sh script to send transactions between ETH and UMEE._

1. Clone the repo
   ```sh
   git clone https://github.com/bartosian/helper_scripts.git
   ```
2. Add file to the same directory with amounts to send. Make sure each amount is on new line and toital number of them is equal to "count" option
   ```sh
   touch name_of_file.txt
   ```
3. Make transacter file executable: 
   ```sh
   chmod +x transacter.sh
   ```
4. Update eth_rpc, eth_pk in transacter file.
5. Start transacter executing following command: 
   ```sh
   ./transacter.sh -e <ETH ADDRESS> -u <UMEE ADDRESS> -c <COUNT OF TXs> -f <NAME OF FILE WITH AMOUNTS> -d <DIRECTION OF TXs> -t <DELAY BETWEEN TXS>
   ```
